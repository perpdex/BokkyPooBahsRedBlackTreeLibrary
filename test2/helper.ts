import { expect } from "chai";
import _ from "lodash";

const checkNode = async (tree, node) => {
  const { left, right, red } = await tree.getNode(node);
  let leftBlackHeight = 1;
  let rightBlackHeight = 1;
  if (!left.eq(0)) {
    const leftNode = await tree.getNode(left);
    if (red) {
      expect(leftNode.red).to.eq(false);
    }
    expect(leftNode.parent).to.eq(node);
    const leftRes = await checkNode(tree, left);
    leftBlackHeight = leftRes.blackHeight;
  }
  if (!right.eq(0)) {
    const rightNode = await tree.getNode(right);
    if (red) {
      expect(rightNode.red).to.eq(false);
    }
    expect(rightNode.parent).to.eq(node);
    const rightRes = await checkNode(tree, right);
    rightBlackHeight = rightRes.blackHeight;
  }
  expect(leftBlackHeight).to.eq(rightBlackHeight);
  return {
    blackHeight: leftBlackHeight + (red ? 0 : 1),
  };
};

const checkRedBlackConditions = async (tree) => {
  const root = await tree.root();
  if (!root.eq(0)) {
    const rootNode = await tree.getNode(root);
    expect(rootNode.parent).to.eq(0);
    await checkNode(tree, root);
  }
};

export const checkConsistency = async (tree) => {
  const keys = await getKeys(tree);
  expect(keys).to.deep.eq(_.sortBy(keys));

  const emptyNode = await tree.getNodeUnsafe(0);
  expect(emptyNode.parent).to.eq(0);
  expect(emptyNode.left).to.eq(0);
  expect(emptyNode.right).to.eq(0);
  expect(emptyNode.red).to.eq(false);

  await checkRedBlackConditions(tree);
};

export const getKeys = async (tree) => {
  let key = await tree.first();
  const keys = [];
  while (!key.eq(0)) {
    keys.push(key.toNumber());
    key = await tree.next(key);
  }
  return keys;
};
